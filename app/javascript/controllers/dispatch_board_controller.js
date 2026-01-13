import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "job", "unassignedContainer", "timeSlot" ]
  static values = { date: String }

  connect() {
    this.draggedJob = null
    this.draggedFrom = null
  }

  // Handle dragstart on job cards
  dragStart(event) {
    this.draggedJob = event.currentTarget
    this.draggedFrom = event.currentTarget.parentElement
    event.currentTarget.classList.add("opacity-50")
    event.dataTransfer.effectAllowed = "move"
  }

  // Handle dragend
  dragEnd(event) {
    this.jobTargets.forEach(job => job.classList.remove("opacity-50"))
  }

  // Allow drop on unassigned container
  dragOverUnassigned(event) {
    event.preventDefault()
    event.dataTransfer.dropEffect = "move"
    event.currentTarget.classList.add("bg-slate-700/50")
  }

  dragLeaveUnassigned(event) {
    if (event.currentTarget === event.target) {
      event.currentTarget.classList.remove("bg-slate-700/50")
    }
  }

  // Drop on unassigned
  dropUnassigned(event) {
    event.preventDefault()
    event.currentTarget.classList.remove("bg-slate-700/50")

    if (!this.draggedJob) return

    const jobId = this.draggedJob.dataset.jobId
    this.rescheduleJob(jobId, null, null, event.currentTarget)
  }

  // Allow drop on time slots
  dragOverSlot(event) {
    event.preventDefault()
    event.dataTransfer.dropEffect = "move"
    event.currentTarget.classList.add("ring-2", "ring-blue-400")
  }

  dragLeaveSlot(event) {
    if (event.currentTarget === event.target) {
      event.currentTarget.classList.remove("ring-2", "ring-blue-400")
    }
  }

  // Drop on time slot
  dropSlot(event) {
    event.preventDefault()
    event.currentTarget.classList.remove("ring-2", "ring-blue-400")

    if (!this.draggedJob) return

    const jobId = this.draggedJob.dataset.jobId
    const technicianId = event.currentTarget.dataset.technicianId
    const hour = parseInt(event.currentTarget.dataset.hour)
    const minute = Math.round((event.offsetY / event.currentTarget.offsetHeight) * 60)

    const date = new Date(this.dateValue)
    const startsAt = new Date(date.getFullYear(), date.getMonth(), date.getDate(), hour, minute, 0)

    this.rescheduleJob(jobId, technicianId, startsAt.toISOString(), event.currentTarget)
  }

  // Reschedule job via PATCH /jobs/:id/reschedule
  async rescheduleJob(jobId, technicianId, startsAt, target) {
    const originalParent = this.draggedFrom
    const originalHTML = this.draggedJob.outerHTML

    try {
      const response = await fetch(`/jobs/${jobId}/reschedule`, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
        },
        body: JSON.stringify({
          job: {
            technician_id: technicianId,
            starts_at: startsAt
          }
        })
      })

      const data = await response.json()

      if (!data.ok) {
        this.showError("Failed to reschedule: " + Object.values(data.errors).flat().join(", "))
        return
      }

      // Optimistic update: move card to new location
      if (target.classList.contains("unassigned-container")) {
        target.appendChild(this.draggedJob)
      } else {
        target.appendChild(this.draggedJob)
      }

      this.draggedJob.classList.remove("opacity-50")
      this.draggedJob = null
      this.draggedFrom = null

      // Show success message
      this.showSuccess("Job rescheduled successfully")

      // Optionally: reload the board after a short delay to sync state
      setTimeout(() => window.location.reload(), 1500)
    } catch (error) {
      this.showError("Network error: " + error.message)
      // Restore original position
      if (originalParent && originalParent.isConnected) {
        originalParent.insertAdjacentHTML("beforeend", originalHTML)
      }
    }
  }

  showError(message) {
    const alert = document.createElement("div")
    alert.className = "fixed top-4 right-4 bg-red-500 text-white px-4 py-2 rounded-md shadow-lg z-50"
    alert.textContent = message
    document.body.appendChild(alert)
    setTimeout(() => alert.remove(), 4000)
  }

  showSuccess(message) {
    const alert = document.createElement("div")
    alert.className = "fixed top-4 right-4 bg-green-500 text-white px-4 py-2 rounded-md shadow-lg z-50"
    alert.textContent = message
    document.body.appendChild(alert)
    setTimeout(() => alert.remove(), 3000)
  }
}
